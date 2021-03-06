defmodule Postoffice.Handlers.Pubsub do
  use Task

  require Logger

  alias GoogleApi.PubSub.V1.Model.PublishResponse
  alias Postoffice.Messaging

  @spec run(any, any, any) :: {:error, :nosent} | {:ok, :sent}
  def run(publisher_target, publisher_id, message) do
    case impl().publish(publisher_target, message) do
      {:ok, _response = %PublishResponse{}} ->
        Logger.info("Succesfully sent pubsub message to #{publisher_target}")

        {:ok, _} =
          Messaging.create_publisher_success(%{
            publisher_id: publisher_id,
            message_id: message.id
          })

        {:ok, :sent}

      {:error, error} ->
        Logger.info("Error trying to process message from PubsubConsumer #{error}")

        Messaging.create_publisher_failure(%{
          publisher_id: publisher_id,
          message_id: message.id
        })

        {:error, :nosent}
    end
  end

  defp impl do
    Application.get_env(:postoffice, :pubsub_consumer_impl, Postoffice.Adapters.Pubsub)
  end
end
