import Config

if config_env() != :test do
  config :advent_of_code,
    session_key: System.fetch_env!("AOC_SESSION_KEY")
end
