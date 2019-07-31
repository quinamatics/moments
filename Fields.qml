import CyberTracker.Engine 1.0

RecordField {
    uid: "Moment"

    TextField {
        uid: "Note"
        nameElementUid: "FieldNote"
        multiLine: true
    }

    TextField {
        uid: "InteractionKind"
        nameElementUid: "InteractionKind"
        listElementUid: "InteractionKind"
    }

    LocationField {
        uid: "InteractionLocation"
        nameElementUid: "Location"
    }

    TextField {
        uid: "SourceAnimal"
        nameElementUid: "Animal"
        listElementUid: "Animal"
    }

    TextField {
        uid: "SourceSize"
        nameElementUid: "GroupSize"
        listElementUid: "GroupSize"
    }

    LocationField {
        uid: "SourceLocation"
        nameElementUid: "Location"
    }

    TextField {
        uid: "TargetAnimal"
        nameElementUid: "Animal"
        listElementUid: "Animal"
    }

    TextField {
        uid: "TargetSize"
        nameElementUid: "GroupSize"
        listElementUid: "GroupSize"
    }

    LocationField {
        uid: "TargetLocation"
        nameElementUid: "Location"
    }
}
