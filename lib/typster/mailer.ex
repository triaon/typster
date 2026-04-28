defmodule Typster.Mailer do
  @moduledoc "Swoosh mailer used for outbound email delivery"
  use Swoosh.Mailer, otp_app: :typster
end
