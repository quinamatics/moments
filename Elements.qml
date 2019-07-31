import CyberTracker.Engine 1.0

Element {

    Element {
        uid: "UserName"
        name: "User name"

        Element {
            uid: "User1"
            name: "Justin"
        }

        Element {
            uid: "User2"
            name: "Brandon"
        }
    }

    Element {
        uid: "FieldNote"
        name: "Field note"
    }

    Element {
        uid: "InteractionKind"
        name: "Select Interaction"

        Element {
            uid: "InteractionChasing"
            name: "Chasing"
            color: "red"
        }

        Element {
            uid: "InteractionHunting"
            name: "Hunting"
            color: "blue"
        }

        Element{
            uid: "InteractionFoodCompetition"
            name: "Competition (Food)"
            color: "magenta"
        }

        Element{
            uid: "InteractionCompetition"
            name: "Competition (Other)"
            color: "purple"
        }
    }

    Element {
        uid: "Location"
        name: "Location"
    }

    Element {
        uid: "Animal"
        name: "Select Animal"

        Element {
            uid: "Lion"
            name: "Lion"
            color: "red"
        }

        Element {
            uid: "Zebra"
            name: "Zebra"
            color: "magenta"
        }

        Element {
            uid: "Hartebeest"
            name: "Hartebeest"
            color: "blue"
        }

        Element {
            uid: "Elephant"
            name: "Elephant"
            color: "green"
        }

        Element {
            uid: "Gazelle"
            name: "Gazelle"
            color: "steel blue"
        }

        Element {
            uid: "Warthog"
            name: "Warthog"
            color: "yellow"
        }

        Element {
            uid: "Topi"
            name: "Topi"
            color: "black"
        }
    }

    Element {
        uid: "GroupSize"
        name: "Select Size"

        Element {
            uid: "Size1"
            name: "1"
            tag: { "radius": 50 }
        }

        Element {
            uid: "Size2"
            name: "2"
            tag: { "radius": 100 }
        }

        Element {
            uid: "Size3-5"
            name: "3-5"
            tag: { "radius": 150 }
        }

        Element {
            uid: "Size6-9"
            name: "6-9"
            tag: { "radius": 200 }
        }

        Element {
            uid: "Size10-49"
            name: "10-49"
            tag: { "radius": 250 }
       }

        Element {
            uid: "Size50-99"
            name: "50-99"
            tag: { "radius": 300 }
        }

        Element {
            uid: "Size100-499"
            name: "100-499"
            tag: { "radius": 450 }
        }

        Element {
            uid: "500"
            name: "500+"
            tag: { "radius": 500 }
        }
    }
}
