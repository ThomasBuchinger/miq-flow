# Changelog

## [unreleased] 2019-??-??
### Added
- Add user guide (#39)

### Fixed
- Updated outdated information in  README (#39)

## [1.0.0-rc1] 2019-01-28
### Added
- Initial commit
- Added APACHE-2 LICENSE
- Features:
  - Configuration sources:
    - YAML files
    - CLI parameter
    - Environment variables 
  - Returns exit codes
  - Query ManageIQ API
  - Repository is cloned in the background and cleaned before the 
    program exists
  - Supports multiple Automate Domains
- Availalbe Commands:
  - miq-flow deploy
  - miq-flow branch inspect
  - miq-flow branch list
  - miq-flow domain list
- Availalbe Providers:
  - provider_local (to be used on MIQ appliances)
  - provider_noop (does nothing)
  - provider_docker (local development)
  
