import Config

if config_env() != :test do
  config :advent_of_code,
    session_key: System.fetch_env!("AOC_SESSION_KEY"),
    user_agent: System.fetch_env!("AOC_USER_AGENT"),
    api_cooldown_seconds: 300
end
