module GenericExceptions
  class GenericError < StandardError; end

  class NotFoundError < GenericError; end
end
