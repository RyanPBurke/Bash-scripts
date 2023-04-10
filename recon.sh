#!/bin/bash

# Prompt the user to enter a project name
read -p "Enter a project name: " project_name

# Prompt the user for an IP address to scan
read -p "Enter an IP address to scan: " ip

# Run an initial nmap scan and save the results to a file
echo "Running nmap scan on $ip..."
nmap -p- -sS -sV -oN "$project_name-nmap-results.txt" $ip

# Parse the nmap results to determine if http or https is open
if grep -q -E '80\/(tcp|http)|443\/(tcp|https)' "$project_name-nmap-results.txt"; then
  echo "Port 80 (HTTP) or 443 (HTTPS) is open. Running additional scans..."
  
  # If http or https is open, run dirbuster and whatweb scans
  if grep -q -E '80\/(tcp|http)' "$project_name-nmap-results.txt"; then
    echo "Running dirbuster scan on $ip..."
    dirb "http://$ip" -o "$project_name-dirbuster-results.txt"
    echo "Running whatweb scan on $ip..."
    whatweb "http://$ip" > "$project_name-whatweb-results.txt"
  elif grep -q -E '443\/(tcp|https)' "$project_name-nmap-results.txt"; then
    echo "Running dirbuster scan on $ip..."
    dirb "https://$ip" -o "$project_name-dirbuster-results.txt"
    echo "Running whatweb scan on $ip..."
    whatweb "https://$ip" > "$project_name-whatweb-results.txt"
  fi
  
  # Display the results to the user
  echo "Results:"
  cat "$project_name-nmap-results.txt"
  cat "$project_name-dirbuster-results.txt"
  cat "$project_name-whatweb-results.txt"
  
  # Prompt the user to save the results to a file
  read -p "Do you want to save the results to a file? (y/n): " save_result
  if [[ $save_result == "y" || $save_result == "Y" ]]; then
    read -p "Enter the filename to save the results: " filename
    echo "Saving results to $filename..."
    cat "$project_name-nmap-results.txt" "$project_name-dirbuster-results.txt" "$project_name-whatweb-results.txt" > "$filename"
    echo "Results saved to $filename"
  fi
else
  echo "Port 80 (HTTP) or 443 (HTTPS) is not open."
  echo "Results:"
  cat "$project_name-nmap-results.txt"
  
  # Prompt the user to save the results to a file
  read -p "Do you want to save the results to a file? (y/n): " save_result
  if [[ $save_result == "y" || $save_result == "Y" ]]; then
    read -p "Enter the filename to save the results: " filename
    echo "Saving results to $filename..."
    cat "$project_name-nmap-results.txt" > "$filename"
    echo "Results saved to $filename"
  fi
fi

# Clean up the temporary files
rm "$project_name-nmap-results.txt" "$project_name-dirbuster-results.txt" "$project_name-whatweb-results.txt"
