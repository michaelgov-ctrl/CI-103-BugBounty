import requests
import subprocess

def fetch_from_crtsh(domain):
    print(f"[+] Fetching subdomains from crt.sh for: {domain}")
    url = f"https://crt.sh/?q=%25.{domain}&output=json"
    try:
        r = requests.get(url, timeout=10)
        if r.status_code != 200:
            print("[!] Failed to fetch from crt.sh")
            return []
        entries = r.json()
        subdomains = set()
        for entry in entries:
            name = entry['name_value']
            for sub in name.split('\n'):
                if '*' not in sub:
                    subdomains.add(sub.strip())
        return sorted(subdomains)
    except Exception as e:
        print(f"[!] crt.sh error: {e}")
        return []

def fetch_with_sublist3r(domain):
    print(f"[+] Running Sublist3r for: {domain}")
    try:
        output = subprocess.check_output(["sublist3r", "-d", domain, "-n", "-t", "20"], text=True)
        return sorted(set(line.strip() for line in output.splitlines() if domain in line))
    except Exception as e:
        print(f"[!] Sublist3r error: {e}")
        return []

def main():
    domain = input("Enter the domain (e.g. drexel.edu): ").strip()

    all_subs = set()

    crtsh_subs = fetch_from_crtsh(domain)
    print(f"[+] Found {len(crtsh_subs)} subdomains from crt.sh")
    all_subs.update(crtsh_subs)

    sublist3r_subs = fetch_with_sublist3r(domain)
    print(f"[+] Found {len(sublist3r_subs)} subdomains from Sublist3r")
    all_subs.update(sublist3r_subs)

    print("\n[+] All unique subdomains found:")
    for sub in sorted(all_subs):
        print(sub)

    with open(f"{domain}_subdomains.txt", "w") as f:
        f.write("\n".join(sorted(all_subs)))
    print(f"\n[+] Results saved to {domain}_subdomains.txt")

if __name__ == "__main__":
    main()
