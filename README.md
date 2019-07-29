
## Moments: Interactive Map-Based Data Capture

Moments was inspired by the two biggest frustrations I and many other field researchers experienced while collecting wildlife data; the absence of in-software visualization tools and the inability to capture complex relationships between data. My software features an political or physical maps, on which researchers can input wildlife species locations and connect them to form interactions. In addition to facilitating data visualization and input, Moments also features novel data storage and sharing features, allowing data to be exported in spreadsheet, map-image, and notes forms. 

This tool was written entirely in QML and tested through Qt Creator, although I also worked closely with CyberTracker Conservation's Justin Steventon to develop a C++ platform to support data storage and classification. Moments has been and is actively used and tested in field research by teams from the Mara Lion Conservation Programme in Kenya's Maasai Mara Reserve and from Lion Landscapes in the Loisaba and Samburu Conservancies. The full version of Moments is projected to be released in late-summer 2019; in the meantime, contact me at brandonznyc@gmail.com for software demos, consulting sessions, and/or testing instructions. 

# Interactive UI from Start to Finish

Moments's most valuable concept is its easy-of-use. There are no selection or input screens -- all of the data input occurs in the centralized map page. Built using an ESRI-supported backend, Moments offers the complete set of map tools and features, giving researchers full control over:

1) Map Selection: We allow users to choose from political, physical, and contour map baselayers during setup.
2) Data Input: User-inputted data is stored as geographical coordinates, which are also displayed on their screens as a ESRI geospatial reference. 
3) Map and Data Visualization: Once users are finished recording, the "moment" is saved as a .png file for immediate access in-app or easy integration into research presentations. 


# General Purpose Specialized for Wildlife Interactions
is a data-capture application that I created for wildlife trackers to record data on complex animal interactions. The app uses visual map-based input, and stores data both in a database and as a series of snapshots that researchers can visually analyze, too. The code is located in moments/Moments/qml/Main.qml
     
If you have any questions, please contact brandonznyc@gmail.com
