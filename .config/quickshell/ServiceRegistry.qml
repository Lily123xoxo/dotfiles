pragma Singleton
import QtQuick

QtObject {
    property var _services: ({})
    function register(name, instance) {
        _services[name] = instance
    }

    function get(name) {
        let service = _services[name] ?? null
        if (!service) console.warn("ServiceRegistry: no service registered for '" + name + "'")
        return service
    }
}