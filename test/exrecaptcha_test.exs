defmodule ExrecaptchaTest do
  use ExUnit.Case
  use ExVCR.Mock

  test "verify returns :ok if sent successfully" do

    remote_ip = {127, 0, 0, 0}
    challenge = "CHALLENGE"
    response = "RESPONSE"

    request_url = "http://www.google.com/recaptcha/api/verify?challenge=CHALLENGE&privatekey=YOUR_PRIVATE_KEY&remoteip=127.0.0.0&response=RESPONSE"
    response_body = "true\nsuccess"

    use_cassette :stub, [url: request_url,
                         method: "post",
                         status_code: 200,
                         body: response_body] do

      success = Exrecaptcha.verify(remote_ip, challenge, response)
      assert :ok = success
    end
  end

  test "verify raises error if sent unsuccessfully" do

    remote_ip = {127, 0, 0, 0}
    challenge = "CHALLENGE"
    response = "RESPONSE"

    request_url = "http://www.google.com/recaptcha/api/verify?challenge=CHALLENGE&privatekey=YOUR_PRIVATE_KEY&remoteip=127.0.0.0&response=RESPONSE"
    response_body = "false\nincorrect-captcha-sol"

    use_cassette :stub, [url: request_url,
                         method: "post",
                         status_code: 200,
                         body: response_body] do

      assert_raise RuntimeError, "incorrect-captcha-sol", fn ->
        Exrecaptcha.verify(remote_ip, challenge, response)
      end
    end
  end

end
