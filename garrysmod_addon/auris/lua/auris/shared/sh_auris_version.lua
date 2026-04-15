-- Single source of truth for the API version.
-- Submodules compare against this to guard against breaking changes.

Auris = Auris or {}

---@type string
Auris.VERSION = "2.0.0"
