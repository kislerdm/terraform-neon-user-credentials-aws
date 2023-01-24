# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.1.1] - 2023-01-25

### Changed

- Bumped the Lambda release
  to [v0.1.2](https://github.com/kislerdm/aws-lambda-secret-rotation/releases/tag/plugin%2Fneon%2Fv0.1.2)

## [v0.1.0] - 2023-01-24

### Added

- Neon users access credentials: an AWS Secretsmanager's secret per user.
- AWS Lambda to [rotate](https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotating-secrets.html) the secret's
  version. The codebase relies on
  the [Neon plugin](https://github.com/kislerdm/aws-lambda-secret-rotation/releases/tag/plugin%2Fneon%2Fv0.1.1).
