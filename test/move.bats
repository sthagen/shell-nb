#!/usr/bin/env bats

load test_helper

# no argument #################################################################

@test "'move' with no arguments exits with status 1." {
  {
    run "${_NB}" init
    run "${_NB}" add "example.md" --content "Example content."
    run "${_NB}" notebooks add "destination"
  }

  run "${_NB}" move --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with 1:

  [[ "${status}" -eq 1 ]]

  # Does not delete file:

  [[ -e "${_NOTEBOOK_PATH}/example.md" ]]

  # Does not create git commit:

  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  ! git log | grep '\[nb\] Delete'

  # Prints help:

  [[ "${lines[0]}" =~ Usage\:   ]]
  [[ "${lines[1]}" =~ nb\ move  ]]
}

# <selector> ##################################################################

@test "'move <selector> <notebook>:' with empty repo exits with 1 and prints help." {
  {
    run "${_NB}" init
  }

  run "${_NB}" move 1 destination:

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1              ]]
  [[ "${lines[0]}" =~ Not\ found  ]]
  [[ "${lines[0]}" =~ 1           ]]

}

@test "'move <invalid> <notebook>:' exits with 1 and prints help." {
  {
    run "${_NB}" init
    run "${_NB}" add "example.md" --content "Example content."
    run "${_NB}" notebooks add "destination"
  }

  run "${_NB}" move "invalid" destination: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1              ]]
  [[ "${lines[0]}" =~ Not\ found  ]]
  [[ "${lines[0]}" =~ invalid     ]]

}

@test "'move <selector> <invalid>:' exits with 1 and prints help." {
  {
    run "${_NB}" init
    run "${_NB}" add "example.md" --content "Example content."
    run "${_NB}" notebooks add "destination"
  }

  run "${_NB}" move 1 invalid: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                                ]]
  [[ "${lines[0]}" =~ Target\ notebook\ not\ found  ]]
  [[ "${lines[0]}" =~ invalid                       ]]
}

@test "'move <selector> <notebook>: (no force)' returns 0 and moves note." {
  skip "Determine how to test interactive prompt."
  {
    run "${_NB}" init
    run "${_NB}" add "example.md" --content "Example content."
    run "${_NB}" notebooks add "destination"

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"

    [[ -e "${_NOTEBOOK_PATH}/example.md" ]]
  }

  run "${_NB}" move "example.md" destination:

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                      ]]
  [[ ! -e "${_NOTEBOOK_PATH}/example.md"  ]]
}

# <scope>:<selector> ##########################################################

@test "'move <scope>:<selector> <notebook>:' with <filename> argument moves note." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add "one"
    run "${_NB}" one:add "example.md" --content "Example content."

    [[ -e "${NB_DIR}/one/example.md"  ]]
  }

  run "${_NB}" move one:example.md home: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0              ]]
  [[ "${output}" =~ Moved\ to       ]]
  [[ "${output}" =~ home:1          ]]
  [[ "${output}" =~ home:example.md ]]
}

@test "'<scope>:move <selector> <notebook>:' with <filename> argument moves note." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add "one"
    run "${_NB}" use "one"
    run "${_NB}" add

    _filename=$("${_NB}" list -n 1 --no-id --filenames | head -1)

    echo "\${_filename:-}: ${_filename:-}"

    run "${_NB}" use "home"

    [[ -n "${_filename}"                ]]
    [[ -e "${NB_DIR}/one/${_filename}"  ]]
  }

  run "${_NB}" one:move "${_filename}" home: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0                    ]]
  [[ "${output}" =~ Moved\ to             ]]
  [[ "${output}" =~ home:[A-Za-z0-9]*     ]]
  [[ "${output}" =~ home:[A-Za-z0-9]+.md  ]]
}

@test "'<scope>:<selector> move <notebook>:' with <filename> argument moves note." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add "one"
    run "${_NB}" use "one"
    run "${_NB}" add

    _filename=$("${_NB}" list -n 1 --no-id --filenames | head -1)

    echo "\${_filename:-}: ${_filename:-}"

    run "${_NB}" use "home"

    [[ -n "${_filename}"                ]]
    [[ -e "${NB_DIR}/one/${_filename}"  ]]
  }

  run "${_NB}" one:"${_filename}" move home: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0                    ]]
  [[ "${output}" =~ Moved\ to             ]]
  [[ "${output}" =~ home:[A-Za-z0-9]*     ]]
  [[ "${output}" =~ home:[A-Za-z0-9]+.md  ]]
}

@test "'<selector> <scope>:move <notebook>:' with <filename> argument moves note." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add "one"
    run "${_NB}" use "one"
    run "${_NB}" add

    _filename=$("${_NB}" list -n 1 --no-id --filenames | head -1)

    echo "\${_filename:-}: ${_filename:-}"

    run "${_NB}" use "home"

    [[ -n "${_filename}"                ]]
    [[ -e "${NB_DIR}/one/${_filename}"  ]]
  }

  run "${_NB}" "${_filename}" one:move home: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0                    ]]
  [[ "${output}" =~ Moved\ to             ]]
  [[ "${output}" =~ home:[A-Za-z0-9]*     ]]
  [[ "${output}" =~ home:[A-Za-z0-9]+.md  ]]
}

# <filename> ##################################################################

@test "'move' with <filename> argument successfully moves note." {
  {
    run "${_NB}" init
    run "${_NB}" add "example.md" --content "Example content."
    run "${_NB}" notebooks add "destination"
  }

  run "${_NB}" move "example.md" destination: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${_NOTEBOOK_PATH}/example.md"    ]]
  [[ -e "${NB_DIR}/destination/example.md"  ]]

  # Creates git commit:

  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Moved\ to               ]]
  [[ "${output}" =~ destination:1           ]]
  [[ "${output}" =~ destination:example.md  ]]
}

# <id> ########################################################################

@test "'move' with <id> argument successfully moves note." {
  {
    run "${_NB}" init
    run "${_NB}" add "example.md" --content "Example content."
    run "${_NB}" notebooks add "destination"

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NB}" move 1 destination: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${_NOTEBOOK_PATH}/example.md"    ]]
  [[ -e "${NB_DIR}/destination/example.md"  ]]

  # Creates git commit:

  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Moved\ to               ]]
  [[ "${output}" =~ destination:1           ]]
  [[ "${output}" =~ destination:example.md  ]]
}

@test "'<id> move' successfully moves note." {
  {
    run "${_NB}" init
    run "${_NB}" add "example.md" --content "Example content."
    run "${_NB}" notebooks add "destination"
  }

  run "${_NB}" 1 move destination: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${_NOTEBOOK_PATH}/example.md"    ]]
  [[ -e "${NB_DIR}/destination/example.md"  ]]

  # Creates git commit:

  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Moved\ to                   ]]
  [[ "${output}" =~ destination:[A-Za-z0-9]*    ]]
  [[ "${output}" =~ destination:[A-Za-z0-9]+.md ]]
}

@test "'move' with <id> argument and trailing colon on destination successfully moves note." {
  {
    run "${_NB}" init
    run "${_NB}" add "example.md" --content "Example content."
    run "${_NB}" notebooks add "destination"
  }

  run "${_NB}" move 1 destination: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${_NOTEBOOK_PATH}/example.md"    ]]
  [[ -e "${NB_DIR}/destination/example.md"  ]]

  # Creates git commit:

  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Moved\ to               ]]
  [[ "${output}" =~ destination:1           ]]
  [[ "${output}" =~ destination:example.md  ]]
}

# <path> ######################################################################

@test "'move' with <path> argument successfully moves note." {
  {
    run "${_NB}" init
    run "${_NB}" add "example.md" --content "Example content."
    run "${_NB}" notebooks add "destination"
  }

  run "${_NB}" move "${_NOTEBOOK_PATH}/example.md" destination: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${_NOTEBOOK_PATH}/example.md"    ]]
  [[ -e "${NB_DIR}/destination/example.md"  ]]

  # Creates git commit:

  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Moved\ to               ]]
  [[ "${output}" =~ destination:1           ]]
  [[ "${output}" =~ destination:example.md  ]]
}

# <title> #####################################################################

@test "'move' with <title> argument successfully moves note." {
  {
    run "${_NB}" init
    run "${_NB}" add --title "Example Title" --filename "example.md"
    run "${_NB}" notebooks add "destination"
  }

  run "${_NB}" move "Example Title" destination: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${_NOTEBOOK_PATH}/example.md"    ]]
  [[ -e "${NB_DIR}/destination/example.md"  ]]

  # Creates git commit:

  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Moved\ to               ]]
  [[ "${output}" =~ destination:1           ]]
  [[ "${output}" =~ destination:example.md  ]]
}

# <folder> ####################################################################

@test "'move' with <folder> argument successfully moves note." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add "destination"
    run "${_NB}" import "${BATS_TEST_DIRNAME}/fixtures/Example Folder"

    [[ -d "${NB_DIR}/home/Example Folder" ]]
  }

  run "${_NB}" move "Example Folder" destination: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0 ]]

  # Moves folder:

  [[ ! -e "${_NOTEBOOK_PATH}/Example Folder"    ]]
  [[ -e "${NB_DIR}/destination/Example Folder"  ]]

  # Creates git commit:

  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Moved\ to                     ]]
  [[ "${output}" =~ destination:1                 ]]
  [[ "${output}" =~ destination:Example\\\ Folder ]]
}

# local #######################################################################

@test "'move' to local with <filename> argument successfully moves note." {
  {
    run "${_NB}" init
    run "${_NB}" add "example.md" --content "Example content."

    [[ -e "${NB_DIR}/home/example.md" ]]

    run "${_NB}" notebooks init "${_TMP_DIR}/example-local"

    cd "${_TMP_DIR}/example-local"

    [[ "$(pwd)" == "${_TMP_DIR}/example-local" ]]
  }

  run "${_NB}" move "home:example.md" local: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # exits with status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${_NOTEBOOK_PATH}/example.md"        ]]
  [[ -e "${_TMP_DIR}/example-local/example.md"  ]]

  # Creates git commit:

  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Moved\ to         ]]
  [[ "${output}" =~ local:1           ]]
  [[ "${output}" =~ local:example.md  ]]
}

@test "'move' from local with <filename> argument successfully moves note." {
  {
    run "${_NB}" init
    run "${_NB}" add "example.md" --content "Example content."
    run "${_NB}" notebooks add "destination"

    run "${_NB}" notebooks init "${_TMP_DIR}/example-local"

    cd "${_TMP_DIR}/example-local"

    [[ "$(pwd)" == "${_TMP_DIR}/example-local" ]]

    run "${_NB}" add "local-example.md" --content "local example content"
  }

  run "${_NB}" move "local-example.md" home: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ -e "${_NOTEBOOK_PATH}/local-example.md"            ]]
  [[ ! -e "${_TMP_DIR}/example-local/local-example.md"  ]]

  # Creates git commit:

  cd "${_TMP_DIR}/example-local" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Moved\ to             ]]
  [[ "${output}" =~ home:2                ]]
  [[ "${output}" =~ home:local-example.md ]]
}

@test "'move' from local with local:<filename> argument successfully moves note." {
  {
    run "${_NB}" init
    run "${_NB}" add "example.md" --content "Example content."
    run "${_NB}" notebooks add "destination"

    run "${_NB}" notebooks init "${_TMP_DIR}/example-local"

    cd "${_TMP_DIR}/example-local"

    [[ "$(pwd)" == "${_TMP_DIR}/example-local" ]]

    run "${_NB}" add "local-example.md" --content "local example content"
  }

  run "${_NB}" move "local:local-example.md" home: --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ -e "${_NOTEBOOK_PATH}/local-example.md"            ]]
  [[ ! -e "${_TMP_DIR}/example-local/local-example.md"  ]]

  # Creates git commit:

  cd "${_TMP_DIR}/example-local" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Moved\ to             ]]
  [[ "${output}" =~ home:2                ]]
  [[ "${output}" =~ home:local-example.md ]]
}

# help ########################################################################

@test "'help move' exits with status 0." {
  run "${_NB}" help move

  [[ ${status} -eq 0 ]]
}

@test "'help move' prints help information." {
  run "${_NB}" help move

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Usage\:  ]]
  [[ "${lines[1]}" =~ nb\ move ]]
}
