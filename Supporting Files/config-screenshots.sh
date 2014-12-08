export languages="en-US"


# SIMULATORS
# ==========
# The simulators we want to run the script against, declared as a Bash array.
# Run `instruments -s devices` to get a list of all the possible string values.

declare -xa simulators=(
"iPhone 6 (8.1 Simulator)",
"iPhone 6 Plus (8.1 Simulator)",
"iPhone 5 (8.1 Simulator)",
"iPhone 4s (8.1 Simulator)"
)
