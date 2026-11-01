## Install

```bash
sudo apt update
sudo apt install ffmpeg gifsicle
```

## Usage

```bash
ffmpeg -i [input.mp4] -filter_complex "[0:v]fps=8,scale=340:-1:flags=lanczos,split[a][b];[a]palettegen=max_colors=112:stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=4:diff_mode=rectangle" -an -loop 0 -y temp.gif && gifsicle -O3 --no-comments --no-names temp.gif -o output.gif && rm temp.gif
```

## Results

<div align="left">
  <img src="https://i.ibb.co.com/svhzGRMW/output.gif" width="200" />
</div>
