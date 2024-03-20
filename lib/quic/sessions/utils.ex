defmodule Quic.Sessions.CodeGenerator do
  @upper_alpha_chars ~w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)

  def generate_code(0), do: ""
  def generate_code(size) when size > 0 do
    Enum.random(@upper_alpha_chars) <> generate_code(size - 1)
  end
end
