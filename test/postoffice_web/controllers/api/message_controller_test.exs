defmodule PostofficeWeb.Api.MessageControllerTest do
  use PostofficeWeb.ConnCase

  alias Postoffice.Messaging

  @create_attrs %{
    attributes: %{},
    payload: %{"key" => "test", "key_list" => [%{"letter" => "a"}, %{"letter" => "b"}]},
    topic: "test"
  }
  @invalid_attrs %{attributes: nil, payload: nil, topic: "test"}
  @bad_message_payload_by_topic %{
    attributes: %{},
    payload: %{"key" => "test", "key_list" => [%{"letter" => "a"}, %{"letter" => "b"}]},
    topic: "no_topic"
  }

  def fixture(:message) do
    {:ok, topic} = Messaging.create_topic(%{name: "test", origin_host: "example.com", id: 1})
    {:ok, message} = Messaging.create_message(topic, @create_attrs)
    message
  end

  setup %{conn: conn} do
    {:ok, _topic} = Messaging.create_topic(%{name: "test", origin_host: "example.com"})
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create message" do
    test "renders message when data is valid", %{conn: conn} do
      conn = post(conn, Routes.api_message_path(conn, :create), @create_attrs)
      assert %{"public_id" => id} = json_response(conn, 201)["data"]
    end

    test "renders errors when topic does not exists", %{conn: conn} do
      conn = post(conn, Routes.api_message_path(conn, :create), @bad_message_payload_by_topic)
      assert json_response(conn, 400)["data"]["errors"] == %{"topic" => ["is invalid"]}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.api_message_path(conn, :create), @invalid_attrs)

      assert json_response(conn, 400)["data"]["errors"] == %{
               "attributes" => ["can't be blank"],
               "payload" => ["can't be blank"]
             }
    end
  end
end
