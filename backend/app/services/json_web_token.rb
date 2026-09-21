class JsonWebToken
  ALGORITHM = "HS256"
  EXPIRATION = 24.hours

  def self.encode(payload, expires_at = EXPIRATION.from_now)
    payload = payload.merge(exp: expires_at.to_i)

    JWT.encode(
      payload,
      secret_key,
      ALGORITHM
    )
  end

  def self.decode(token)
    decoded = JWT.decode(
      token,
      secret_key,
      true,
      algorithm: ALGORITHM
    )

    decoded.first
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end

  def self.secret_key
    Rails.application.secret_key_base
  end

  private_class_method :secret_key
end