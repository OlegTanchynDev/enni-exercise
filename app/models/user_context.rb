# frozen_string_literal: true

# Pundit's "user" is a context object, not a bare User — it carries both the
# (possibly impersonated) current_user and the true_user. This skeleton has no
# impersonation, so current_user == true_user, but policies read
# `user_context.current_user` so the pattern matches production Enni exactly.
UserContext = Struct.new(:current_user, :true_user, keyword_init: true)
