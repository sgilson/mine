import Mix.Config

unless Mix.env() in [:prod, :bench] do
  config :git_hooks,
    verbose: true,
    hooks: [
      pre_commit: [
        tasks: [
          "mix clean",
          "mix compile --warnings-as-errors",
          "mix format --check-formatted",
          "mix test"
        ]
      ]
    ]
end
