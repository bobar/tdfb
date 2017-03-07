class TdbException < RuntimeError
  def initialize(message)
    @message = message
  end

  def to_h
    { status: 400, message: @message }
  end
end

class AuthException < RuntimeError
end
