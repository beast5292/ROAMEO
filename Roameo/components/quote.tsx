import React from "react";
import { View, Text, Image, StyleSheet } from "react-native";

const Quote = () => {

  return (
    
    <View style={styles.group68}>
      <Text style={styles.hiSaman}>Hi Saman,</Text>
      <Text style={styles.startHereText}>
        <Text style={styles.span1}>Start</Text>
        <Text style={styles.span2}> here.{"\n"}</Text>
        <Text style={styles.span3}>Roam</Text>
        <Text style={styles.span4}> everywhere.{"\n"}</Text>
        <Text style={styles.span6}>Love</Text>
        <Text style={styles.span8}> every mile.</Text>
      </Text>
      <Image
        style={styles.profileImage}

        source={require("../assets/images/profile_pic.jpg")}
      />
    </View>
  );

};

const styles = StyleSheet.create({
  group68: {
    position: "relative",
    padding: 16,
  },
  
  hiSaman: {
    color: "#6b8292",
    textAlign: "left",
    fontFamily: "Inter-Bold",
    fontSize: 18,
    fontWeight: "700",
    position: "absolute",
    left: 2,
    top: 14,
  },
  startHereText: {
    textAlign: "left",
    fontSize: 36,
    fontWeight: "400",
    position: "absolute",
    left: 0,
    top: 40,
    width: 326,
  },
  span1: {
    color: "#44cae9",
    fontFamily: "Inter-Black",
    fontSize: 36,
    fontWeight: "900",
  },
  span2: {
    color: "#ffffff",
    fontFamily: "Inter-ExtraLight",
    fontSize: 36,
    fontWeight: "200",
  },
  span3: {
    color: "#44cae9",
    fontFamily: "Inter-Black",
    fontSize: 36,
    fontWeight: "900",
  },
  span4: {
    color: "#ffffff",
    fontFamily: "Inter-ExtraLight",
    fontSize: 36,
    fontWeight: "200",
  },
  span6: {
    color: "#44cae9",
    fontFamily: "Inter-Black",
    fontSize: 36,
    fontWeight: "900",
  },
  span8: {
    color: "#ffffff",
    fontFamily: "Inter-ExtraLight",
    fontSize: 36,
    fontWeight: "200",
  },
  profileImage: {
    borderRadius: 50,
    width: 45,
    height: 45,
    position: "absolute",
    left: 361,
    top: 0,
    resizeMode: "cover",
  },
});

export default Quote;
