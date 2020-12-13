# Johan's Gemini Capsule

This is a copy of my own Geminispace "capsule" hosted at <gemini://gem.johanbove.info>.

([HTTP proxy](https://portal.mozz.us/gemini/gem.johanbove.info/))

The site is currently running on a _Raspberry Pi 3B+_ at my own house.

## What is the Gemini Protocol?

Gemini is a new internet protocol which:

- Is heavier than gopher
- Is lighter than the web
- Will not replace either
- Strives for maximum power to weight ratio
- Takes user privacy very seriously

<https://portal.mozz.us/gemini/gemini.circumlunar.space/>


## Setup
### post receive hook

    GIT_WORK_TREE=/home/johan/gemini/gem.johanbove.info git checkout -f

### Gemlog script

The `/gemlog/index.gmi` file is generated by the [gemlog.sh script by nytpu](https://tildegit.org/nytpu/gemlog.sh)

The script also generates the `/gemlog/atom.xml` file.

I only added a small addition to output to my own [twtxt.txt](https://johanbove.info/twtxt.txt) feed.

## License

All content is https://creativecommons.org/licenses/by-sa/4.0/ except otherwise noted.
