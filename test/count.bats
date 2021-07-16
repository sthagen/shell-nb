#!/usr/bin/env bats

load test_helper

_setup_count() {
  "${_NB}" init
  cat <<HEREDOC | "${_NB}" add "first.md"
# one
line two
line three
line four
HEREDOC
  cat <<HEREDOC | "${_NB}" add "second.md"
# two
line two
line three
line four
HEREDOC
  cat <<HEREDOC | "${_NB}" add "third.md"
# three
line two
line three
line four
HEREDOC
}

# `count` #####################################################################

@test "'count' exits with 0 and prints count." {
  {
    _setup_count
  }

  run "${_NB}" count

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${lines[0]}"  -eq 3 ]]
}

@test "'count --type <type>' exits with 0 and counts items of type." {
  {
    "${_NB}" init

    cat <<HEREDOC | "${_NB}" add "example.md"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "sample.doc"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "example.doc"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "sample.md"
line one
line two
line three
line four
HEREDOC
  }

  run "${_NB}" count --type document

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0 ]]
  [[ "${lines[0]}"  -eq 2 ]]
}

# help ########################################################################

@test "'help count' exits with status 0." {
  run "${_NB}" help count

  [[ "${status}"    -eq 0       ]]
}

@test "'help count' prints help information." {
  run "${_NB}" help count

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Usage.*:  ]]
  [[ "${lines[1]}" =~ nb\ count ]]
}
