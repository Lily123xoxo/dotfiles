import QtQuick

/*
 * Loads a widget and injects its dependencies from the ServiceRegistry.
 * onCompleted resolves values from the registry at startup to initialise the widget.
 * onLoaded rebinds to the same sources via Qt.binding() to enable runtime hotswapping.
 * This two-phase approach is a workaround: QML's required properties need values at
 * instantiation, but static assignment breaks reactivity, so we resolve then rebind.
 */

Item {

    required property string widgetSource
    required property var dependencies

    width: widgetLoader.item ? widgetLoader.item.width : 0
    height: widgetLoader.item ? widgetLoader.item.height : 0

    Loader {
        id: widgetLoader

        Component.onCompleted: {
            let resolved = {}
            for (let serviceName in dependencies) {
                let service = ServiceRegistry.get(serviceName)
                if (!service) continue
                let props = dependencies[serviceName]
                for (let i = 0; i < props.length; i++) {
                    resolved[props[i]] = service[props[i]]
                }
            }
            widgetLoader.setSource(widgetSource, resolved)
        }

        onLoaded: {
            for (let serviceName in dependencies) {
                let service = ServiceRegistry.get(serviceName)
                if (!service) continue
                let props = dependencies[serviceName]
                for (let i = 0; i < props.length; i++) {
                    let prop = props[i]
                    widgetLoader.item[prop] = Qt.binding(() => service[prop])
                }
            }
        }
    }
}
