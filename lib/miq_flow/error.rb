# frozen_string_literal: true

module MiqFlow
  class Error < StandardError
    EXIT_CODE = 2
  end
  class ConfigurationError < Error
    EXIT_CODE = 3
  end

  class ProviderError < Error
    EXIT_CODE = 10
  end
  class GitError < Error
    EXIT_CODE = 20
  end
  class InvalidReferenceError < GitError
    EXIT_CODE = 21
  end
  class MiqError < Error
    EXIT_CODE = 30
  end
  class UnknownStrategyError < MiqError
    EXIT_CODE = 31
  end
  class ApiError < Error
    EXIT_CODE = 40
  end
  class BadResponseError < ApiError
    EXIT_CODE = 41
  end
  class ConnectionError < ApiError
    EXIT_CODE = 42
  end
end
