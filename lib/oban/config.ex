defmodule Oban.Config do
  @moduledoc false

  @type prune :: :disabled | {:maxlen, pos_integer()} | {:maxage, pos_integer()}

  @type t :: %__MODULE__{
          control_channel: binary(),
          name: module(),
          node: binary(),
          poll_interval: pos_integer(),
          prune: prune(),
          queues: [{atom(), pos_integer()}],
          repo: module(),
          shutdown_grace_period: timeout()
        }

  @enforce_keys [:node, :repo]
  defstruct control_channel: "oban_control",
            name: Oban,
            node: nil,
            poll_interval: 1_000,
            prune: :disabled,
            queues: [default: 10],
            repo: nil,
            shutdown_grace_period: 15_000

  @spec new(Keyword.t()) :: t()
  def new(opts) when is_list(opts) do
    opts = Keyword.put_new(opts, :node, node_name())

    struct!(__MODULE__, opts)
  end

  @spec node_name(%{optional(binary()) => binary()}) :: binary()
  def node_name(env \\ System.get_env()) do
    cond do
      Node.alive?() ->
        to_string(node())

      Map.has_key?(env, "DYNO") ->
        Map.get(env, "DYNO")

      true ->
        :inet.gethostname()
        |> elem(1)
        |> to_string()
    end
  end
end
