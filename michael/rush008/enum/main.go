package main

import (
	"fmt"
	"log"
	"log/slog"
	"net/http"
	"os"
	"time"
)

func main() {
	wrappedClient, err := NewWrappedClient()
	if err != nil {
		log.Fatalf(err.Error())
	}
	defer wrappedClient.Close()

	if err = wrappedClient.GetCSRFToken(); err != nil {
		log.Fatalf(err.Error())
	}

	wrappedClient.logger = slog.New(slog.NewTextHandler(os.Stdout, nil))

	for email := range wrappedClient.GenerateEmails() {
		delay := time.Duration(10 * time.Second) // looks like the site does bucketed rate limiting with 6 requests per minute
		time.Sleep(delay)

		status, err := wrappedClient.EnumerateUser(email)
		if err != nil {
			wrappedClient.logger.Info(err.Error())
		}

		switch status {
		case http.StatusOK:
			wrappedClient.lazyLog(email)
		case http.StatusNoContent:
			wrappedClient.lazyLog(email)
		case http.StatusNotFound:
			wrappedClient.logger.Info("not found", "email", email)
		case http.StatusTooManyRequests:
			status, err = wrappedClient.RetryWithExponentialBackoff(delay, email, wrappedClient.EnumerateUser)
			if err != nil {
				wrappedClient.logger.Error(err.Error())
				continue
			}

			if status == http.StatusOK || status == http.StatusNoContent {
				wrappedClient.lazyLog(email)
			}
		}
	}
}

func (wc WrappedClient) lazyLog(email string) {
	wc.logger.Info("yeet", "email", email)
	wc.logFile.WriteString(fmt.Sprintf("\nfound: %s", email))
}
