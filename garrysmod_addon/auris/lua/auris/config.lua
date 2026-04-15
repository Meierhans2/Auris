-- Operator config. Edit values here; ConVars in server.cfg override these.
-- Restart the map after changes for them to take effect.

return {
    model            = "garrysmod/data/auris/ggml-tiny.en.bin",
    port             = 4000,
    threads          = 4,
    language         = "en",
    debug            = false,
    print_progress   = false,
    print_timestamps = false,
    single_segment   = true,
    no_context       = true,
}
