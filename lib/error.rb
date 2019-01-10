# frozen_string_literal: true

module GitFlow
  class Error < StandardError
    EXIT_CODE = 2
  end

  class ProviderError < Error
    EXIT_CODE = 10
  end
  class GitError < Error
    EXIT_CODE = 11
  end
  class MiqError < Error
    EXIT_CODE = 12
  end
  class ApiError < Error
    EXIT_CODE = 13
  end
  class UnknownStrategyError < Error
    EXIT_CODE = 14
  end
end
