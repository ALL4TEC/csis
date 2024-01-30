# Code quality tools

## [Brakeman](https://github.com/presidentbeef/brakeman)

> A static analysis security vulnerability scanner for Ruby on Rails applications.

```bash
brakeman /path/to/rails/application -o output.html
```

## [Flay](https://github.com/seattlerb/flay)

> Flay analyzes code for structural similarities.

```bash
sudo flay <dir> > flay_report.txt
```

## [Reek](https://github.com/troessner/reek)

> Code smell detector for Ruby.

```bash
reek <dir> > reek_report.txt
```

## [bundler-audit](https://github.com/rubysec/bundler-audit)

> Patch-level verification for Bundler.

```bash
bundle audit > ba_report.txt
```

## [ERB-lint](https://github.com/Shopify/erb-lint)

> Lint your ERB or HTML files.

```bash
erblint --lint-all > erb-lint_report.txt
```

## [Fasterer](https://github.com/DamirSvrtan/fasterer)

> Based on [Fast-ruby](https://github.com/JuanitoFatas/fast-ruby) guidelines and benchmarks.

```bash
fasterer > fasterer_report.txt
```

## [CodeClimate](https://github.com/codeclimate/codeclimate)
