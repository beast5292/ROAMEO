import React from "react";
import { View, Text, Image, StyleSheet, TouchableOpacity } from "react-native";
import { Ionicons } from "@expo/vector-icons"; // Make sure to install @expo/vector-icons

const Quote = () => {
  return (
    <View style={styles.container}>
      {/* Header Section */}
      <View style={styles.header}>
        <Text style={styles.hiSaman}>Hi Saman,</Text>
        <Image
          style={styles.profileImage}
          source={require("../assets/images/profile_pic.jpg")}
        />
      </View>

      {/* Quote Section */}
      <View style={styles.quoteContainer}>
        <Text style={styles.quoteText}>
          <Text style={styles.start}>Start</Text>
          <Text style={styles.here}> here.{"\n"}</Text>
          <Text style={styles.roam}>Roam</Text>
          <Text style={styles.everywhere}> everywhere.{"\n"}</Text>
          <Text style={styles.love}>Love</Text>
          <Text style={styles.everyMile}> every mile.</Text>
        </Text>
      </View>

      {/* Earth Image */}
      <Image
        style={styles.earthImage}
        source={require("../assets/images/earth_img.jpeg")}
      />

      {/* Mood Buttons */}
      <View style={styles.moodButtons}>
        <TouchableOpacity style={styles.moodButton}>
          <Text style={styles.moodText}>Happy</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.moodButton}>
          <Text style={styles.moodText}>Excited</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.moodButton}>
          <Text style={styles.moodText}>Adventurous</Text>
        </TouchableOpacity>
      </View>

      {/* Travel Cards */}
      <View style={styles.travelSection}>
        <View style={styles.travelCard}>
          <Image
            style={styles.travelImage}
            source={require("../assets/images/ella.jpg")}
          />
          <Text style={styles.travelText}>Ella</Text>
        </View>
        <View style={styles.travelCard}>
          <Text style={styles.hotelText}>20h 43min</Text>
          <Text style={styles.hotelBooking}>Hotel booking</Text>
          <Text style={styles.etaText}>ETA - 3:45PM</Text>
          <Text style={styles.nineArchText}>Nine Arch bridge</Text>
        </View>
      </View>

      {/* Navigation Bar */}
      <View style={styles.navBar}>
        <Ionicons name="home-outline" size={28} color="white" />
        <Ionicons name="camera-outline" size={28} color="white" />
        <Ionicons name="add-circle" size={28} color="white" />
        <Ionicons name="chatbubble-outline" size={28} color="white" />
        <Ionicons name="globe-outline" size={28} color="white" />
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#0A0A0A",
    paddingTop: 50,
  },
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginHorizontal: 20,
  },
  hiSaman: {
    color: "#6b8292",
    fontSize: 18,
    fontWeight: "700",
    fontFamily: "Inter-Bold",
  },
  profileImage: {
    width: 45,
    height: 45,
    borderRadius: 25,
    resizeMode: "cover",
  },
  quoteContainer: {
    marginTop: 20,
    marginLeft: 20,
  },
  quoteText: {
    fontSize: 36,
    lineHeight: 42,
    fontWeight: "400",
  },
  start: {
    color: "#44cae9",
    fontWeight: "900",
  },
  here: {
    color: "#FFFFFF",
    fontWeight: "200",
  },
  roam: {
    color: "#44cae9",
    fontWeight: "900",
  },
  everywhere: {
    color: "#FFFFFF",
    fontWeight: "200",
  },
  love: {
    color: "#44cae9",
    fontWeight: "900",
  },
  everyMile: {
    color: "#FFFFFF",
    fontWeight: "200",
  },
  earthImage: {
    width: "100%",
    height: 250,
    marginTop: 20,
    resizeMode: "cover",
  },
  moodButtons: {
    flexDirection: "row",
    justifyContent: "space-evenly",
    marginTop: 10,
  },
  moodButton: {
    backgroundColor: "#2E2E2E",
    paddingHorizontal: 15,
    paddingVertical: 8,
    borderRadius: 20,
  },
  moodText: {
    color: "#FFFFFF",
    fontSize: 14,
  },
  travelSection: {
    flexDirection: "row",
    justifyContent: "space-between",
    marginHorizontal: 20,
    marginTop: 20,
  },
  travelCard: {
    width: "48%",
    backgroundColor: "#1B1B1B",
    borderRadius: 10,
    overflow: "hidden",
    padding: 10,
  },
  travelImage: {
    width: "100%",
    height: 120,
    borderRadius: 10,
  },
  travelText: {
    color: "#FFFFFF",
    marginTop: 5,
    fontWeight: "700",
    fontSize: 16,
  },
  hotelText: {
    color: "#D3D3D3",
    fontSize: 12,
  },
  hotelBooking: {
    color: "#F2BE4D",
    fontWeight: "bold",
    marginVertical: 3,
  },
  etaText: {
    color: "#D3D3D3",
    fontSize: 12,
  },
  nineArchText: {
    color: "#FFFFFF",
    fontWeight: "700",
    marginTop: 5,
  },
  navBar: {
    flexDirection: "row",
    justifyContent: "space-around",
    backgroundColor: "#1B1B1B",
    position: "absolute",
    bottom: 0,
    width: "100%",
    paddingVertical: 15,
  },
});

export default Quote;
