defmodule Addict.Mixfile do
  use Mix.Project

  def project do
    [
      app: :addict,
      version: "0.3.0",
      elixir: "~> 1.9",
      description: description(),
      package: package(),
      docs: &docs/0,
      deps: deps()
    ]
  end

  def application do
    [applications: applications(Mix.env())]
  end

  defp applications(:test) do
    [:plug] ++ applications(:prod)
  end

  defp applications(_) do
    [:phoenix, :ecto_sql, :logger, :crypto]
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:plug, "~> 1.7"},
      {:phoenix, "~> 1.4"},
      {:jason, "~> 1.0"},
      {:ecto_sql, "~> 3.2"},
      {:bcrypt_elixir, "~> 2.0"},
      {:pbkdf2_elixir, "~> 1.0"},
      {:mock, "~> 0.3.3", only: :test},
      {:postgrex, ">= 0.0.0", only: :test},
      {:earmark, "~> 1.4", only: :dev},
      {:ex_doc, "~> 0.21", only: :dev},
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      files: ["lib", "boilerplate", "docs", "mix.exs", "README*", "LICENSE*", "configs*"],
      contributors: ["Nizar Venturini"],
      maintainers: ["Nizar Venturini"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/trenpixster/addict"}
    ]
  end

  defp description do
    """
    Addict allows you to manage users on your Phoenix app easily. Register, login,
    logout, recover password and password updating is available off-the-shelf.
    """
  end

  defp docs do
    {ref, 0} = System.cmd("git", ["rev-parse", "--verify", "--quiet", "HEAD"])
    [source_ref: ref, main: "readme", extras: ["README.md", "configs.md"]]
  end
end
