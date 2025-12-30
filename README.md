# Brook 🌊

**Brook** is a bash script that validates M3U playlist URLs and creates a new playlist containing only working channels.

## Features

- ✅ Validates each channel URL in an M3U playlist
- 🔍 Uses ffmpeg to test stream availability
- 📝 Generates reports of working and broken channels
- 🎯 Creates a clean M3U playlist with only validated channels
- ⚙️ Customizable output files and timeout settings
- 🚀 Simple command-line interface

## Prerequisites

- **ffmpeg** must be installed on your system

### Installation of ffmpeg

**Debian/Ubuntu:**

```bash
sudo apt update
sudo apt install ffmpeg
```

**macOS:**

```bash
brew install ffmpeg
```

**Fedora:**

```bash
sudo dnf install ffmpeg
```

## Installation

1. Clone this repository:

```bash
git clone https://github.com/rjousse18/brook.git
cd brook
```

2. Make the script executable:

```bash
chmod +x brook.sh
```

## Usage

### Basic Usage

```bash
./brook.sh my_playlist.m3u
```

This will:

- Test all channels in `my_playlist.m3u`
- Create `working_channels.txt` with working channels
- Create `broken_channels.txt` with broken channels
- Create `validated_playlist.m3u` with only working channels

### Advanced Usage

```bash
./brook.sh [OPTIONS] <playlist.m3u>
```

### Options

| Option                  | Description                           | Default                  |
| ----------------------- | ------------------------------------- | ------------------------ |
| `-o, --output-ok FILE`  | File to store working channels        | `working_channels.txt`   |
| `-k, --output-ko FILE`  | File to store broken channels         | `broken_channels.txt`    |
| `-p, --playlist FILE`   | Output playlist with working channels | `validated_playlist.m3u` |
| `-t, --timeout SECONDS` | Timeout for each channel test         | `10`                     |
| `-h, --help`            | Display help message                  | -                        |

### Examples

**Test with custom timeout:**

```bash
./brook.sh -t 15 my_playlist.m3u
```

**Custom output files:**

```bash
./brook.sh -o good.txt -k bad.txt -p clean.m3u my_playlist.m3u
```

**Quick validation with short timeout:**

```bash
./brook.sh --timeout 5 --playlist verified.m3u playlist.m3u
```

## How It Works

1. **Parsing**: Brook reads the M3U file line by line
2. **Testing**: Each URL is tested using ffmpeg with a configurable timeout
3. **Validation**: Streams are validated by checking for common error patterns
4. **Output**: Results are written to three files:
   - A text file with working channels
   - A text file with broken channels
   - A new M3U playlist with only working channels

## Output Files

### working_channels.txt

Contains a list of all working channels with their URLs:

```
Channel Name 1 (http://example.com/stream1)
Channel Name 2 (http://example.com/stream2)
```

### broken_channels.txt

Contains a list of all broken channels with their URLs:

```
Broken Channel 1 (http://example.com/dead_stream1)
Broken Channel 2 (http://example.com/dead_stream2)
```

### validated_playlist.m3u

A clean M3U playlist containing only working channels:

```m3u
#EXTM3U
#Channel Name 1
http://example.com/stream1
#Channel Name 2
http://example.com/stream2
```

## Performance Tips

- Adjust the timeout value based on your network speed and stream response times
- For large playlists, consider running the script in the background:
  ```bash
  ./brook.sh large_playlist.m3u > validation.log 2>&1 &
  ```

## Troubleshooting

**Error: ffmpeg must be installed**

- Install ffmpeg following the instructions in the Prerequisites section

**All channels marked as broken**

- Try increasing the timeout value: `./brook.sh -t 20 playlist.m3u`
- Check your internet connection
- Verify that the playlist URLs are accessible

**Script takes too long**

- Reduce the timeout value: `./brook.sh -t 5 playlist.m3u`
- This may cause some slower streams to be marked as broken

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

If you create a derivative work or modify this project, please:

1. Include attribution to Brook with a link to the original repository in your documentation
2. Add a comment in your source code referencing the original project

Example attribution:

```
Based on Brook by Rémi Joussé - https://github.com/yourusername/brook
```

## License

This project is open source and available under the [BSD 3-Clause License](LICENSE) with attribution requirement.

You are free to use, modify, and distribute this software, provided that:

- You retain the copyright notice and license
- You include attribution to the original Brook project in both your code and documentation

See the [LICENSE](LICENSE) file for full details.

## Author

Rémi Joussé

## Changelog

### Version 1.0.0 (2025-12-30)

- Initial release
- M3U playlist validation
- Customizable output files
- Configurable timeout
- Help documentation
