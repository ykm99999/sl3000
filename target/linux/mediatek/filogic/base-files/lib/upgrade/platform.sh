platform_do_upgrade() {
    case "$1" in
        sl3000)
            default_do_upgrade "$1"
            ;;
        *)
            default_do_upgrade "$1"
            ;;
    esac
}
