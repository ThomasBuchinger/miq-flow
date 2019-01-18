# Changelog

## [Unreleased] ????-??-??
### Added
- Initial commit
- Added APACHE-2 LICENSE
- Features:
  - YAML based configuration
  - Returns exit codes
  - Query ManageIQ API
  - Repository is cloned in the background and cleaned before the 
    program exists
  - Supports multiple Automate Domains
- Availalbe Commands:
  - miq-flow deploy
  - miq-flow inspect
  - miq-flow list git
  - miq-flow list miq
- Availalbe Providers:
  - provider_local (to be used on MIQ appliances)
  - provider_noop (does nothing)
  - provider_docker (local development)
  
