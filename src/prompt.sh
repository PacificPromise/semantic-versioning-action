get_stage_prompt() {
  title="Action:"
  prompt="Choose:"
  options=("Increment development environment" "Increment staging environment" "Increment UAT environment" "Increment product environment" "Increment patch version (1.0.xx)" "Increment minor version (1.xx.0)" "Increment major version (xx.0.0)")

  echo "$title"
  PS3="$prompt "
  STAGE=""
  select opt in "${options[@]}" "Quit"; do
    case "$REPLY" in
    1) echo "Chose option: $opt" && increment_tag dev && break ;;
    2) echo "Chose option: $opt" && increment_tag stg && break ;;
    3) echo "Chose option: $opt" && increment_tag uat && break ;;
    4) echo "Chose option: $opt" && increment_tag prd && break ;;
    5) echo "Chose option: $opt" && increment_core_tag patch && break ;;
    6) echo "Chose option: $opt" && increment_core_tag minor && break ;;
    6) echo "Chose option: $opt" && increment_core_tag major && break ;;
    $((${#options[@]} + 1)))
      echo "Goodbye!"
      exit 0
      ;;
    *)
      echo "Choose again !"
      continue
      ;;
    esac
  done
}
