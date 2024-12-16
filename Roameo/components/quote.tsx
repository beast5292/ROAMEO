import React from "react";
import { View, Text, Image, StyleSheet } from "react-native";

const Quote = () => {
  return (
    <View style={styles.container}>
      {/* Profile Section */}
      <View style={styles.header}>
        <Text style={styles.hiSaman}>Hi Saman,</Text>
        <Image
          style={styles.profileImage}
          source={require("../assets/images/profile_pic.jpg")} 
        />
      </View>

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

      <Image
        style={styles.earthImage}
        source={require("../assets/images/earth_img.jpg")}
      />
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
    height: 300,
    position: "absolute",
    bottom: 0,
    resizeMode: "cover",
  },
});

export default Quote;
