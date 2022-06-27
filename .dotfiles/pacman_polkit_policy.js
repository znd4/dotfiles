/* Copy this to /etc/polkit-1/rules.d/packagekit-restrict.rules */

polkit.addRule(function(action, subject) {
    if (/^org\.freedesktop\.packagekit\./.test(action.id)) {
        if subject.isInGroup("wheel") {
            return polkit.Result.AUTH_ADMIN_KEEP;
        }
    }
});
