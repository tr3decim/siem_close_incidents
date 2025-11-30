# SIEM-tool to manage incidents
A Go-based command-line tool for managing SIEM incidents via Positive Technologies Max Patrol [official](https://help.ptsecurity.com/ru-RU/projects/mp10/27.5/help/2959439243) API

The API is used accroding to [Positive Technologies Max Patrol EULA](https://help.ptsecurity.com/ru-RU/projects/mp10/common/eula)

## Features
- **Get incidents**: Fetch and display incident details
- **Update incidents**: Change incident status and assignees
- **Filter by correlation name**: Target specific incident types
- **Batch processing**: Handle multiple incidents at once

## Build from source
1. Clone repo source files
2. Run `go mod init main.go` if it is not exist
3. Install library to work with ".env" - [godotenv](https://github.com/joho/godotenv) - run `go get github.com/joho/godotenv`
4. Build:
    - For Linux run `go build -o siem-tool main.go`
    - For Windows run `GOOS=windows GOARCH=amd64 go build -o siem-tool.exe main.go`

## Installation
1. Download latest release
2. Download or create ".env" file, setup vars
3. If using on Linux - run `chmod +x ./siem-manage-incidents-linux`

## Environment file
You can setup **hostname**, **token** and **assigned** in ".env":
```
hostname="some_host"
token="your_pat_token"
assigned="your-UUID-here"
```
When you run siem-tool it will look up the **hostname**, **token** and **assigned** in ".env" to not use these as flags<br>
If ".env" does not exist it will look for **--hostname**, **--token** and **--assigned** flags

## Usage
`./siem-manage-incidents-linux --flag1 --flag2 ...`

or

`siem-manage-incidents-windows.exe --flag1 --flag2 ...`
<br><br>
  | Flag | Type | Required | Allowed value | Default | Description |
  | :--: | :--: | :------: | :---: | :-----: | :--------- |
  | host | string | yes | DNS name or IP | null | SIEM hostname |
  | token | string | yes | pat_123456789 | null | API PAT token |
  | do | string | yes | get, update | null | What to do: get or update incident(s) |
  | corname | string | no | ID, Correlation name | * | Correlation name or ID (key) of the incident(s).<br>Can be used multiple values divided by "," |
  | date | string | no | YYYY-MM-DDTHH:mm:ss.sssZ | Current day from 00:00 (12:00AM) | From when search incidents (used RFC3339Nano format) |
  | limit | int | no | 1-999 | 999 | Limit of incidents to get or update |
  | assigned | string | yes (if --do update) | 123a-45b-678c-9d-0123ef | null | UUID of user to assign incident(s) to |
  | msg | string | no | False positive | null | Comment for incdent(s) |
  | state | string | yes (if --do update) | Closed, Approved, InProgress or Resolved | null | Status of incident to set |
  | status | string | no | New, Closed or Approved | null | Status of incidents to get or update |
  
## Examples:
If you set **hostname**, **token** and **assigned** in ".env":
```
#Linux
./siem-manage-incidents-linux --do get
./siem-manage-incidents-linux --do get --corname "INC-123,Password_brute" --date "2025-11-30T12:34:56.789Z" --limit 10

#Windows
siem-manage-incidents-windows.exe --do update --state "Closed" --msg "some comment"
siem-manage-incidents-windows.exe --do update --state "Closed" --msg "some comment" --corname "INC-123,Password_brute" --date "2025-11-30T12:34:56.789Z" --limit 10
```

If you do not set **hostname**, **token** and **assigned** in ".env":
```
#Linux
./siem-manage-incidents-linux --host "your_host" --token "your_token" --do get
./siem-manage-incidents-linux --host "your_host" --token "your_token" --do get --corname "INC-123,Password_brute" --date "2025-11-30T12:34:56.789Z" --limit 10

#Windows
siem-manage-incidents-windows.exe --host "hostname" --token "your-token" --assigned "123a-45b-678c-9d-0123ef" --do update --state "Closed" --msg "some comment"
siem-manage-incidents-windows.exe --host "hostname" --token "your-token" --assigned "123a-45b-678c-9d-0123ef" --do update --state "Closed" --msg "some comment" --corname "INC-123,Password_brute" --date "2025-11-30T12:34:56.789Z" --limit 10
```
