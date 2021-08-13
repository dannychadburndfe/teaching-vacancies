# Maintenance mode

The application has a simple routing-level maintenance mode triggered by the `MAINTENANCE_MODE`
environment variable. This needs the app to be restarted to enable maintenance mode, e.g. via
a deploy or a `cf restage`. This is handy in case of a critical bug being discovered where we need
to take the service offline, or in case of maintenance where we want to avoid users interacting
with the service while

When enabled, all requests of all types will be routed to the maintenance page (found under
`app/views/errors/maintenance.html.erb`).