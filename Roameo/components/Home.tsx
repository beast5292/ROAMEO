import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { FontAwesome } from '@expo/vector-icons'; // Updated import

const Home = () => {
  return (
    <View style={styles.container}>
      <Text style={styles.text}>Welcome to ROAMEO</Text>
      
      <View style={styles.iconContainer}>
        <TouchableOpacity style={styles.iconWrapper}>
          <FontAwesome name="phone" size={50} color="#fff" />
          <Text style={styles.iconLabel}>Call</Text>
        </TouchableOpacity>
        
        <TouchableOpacity style={styles.iconWrapper}>
          <FontAwesome name="map" size={50} color="#fff" />
          <Text style={styles.iconLabel}>Map</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#003152',
    padding: 20,
    borderRadius: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 10,
    elevation: 5,
  },
  text: {
    fontSize: 36,
    fontWeight: '700',
    color: '#fff',
    textAlign: 'center',
    marginBottom: 30, 
  },
  iconContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    width: '100%',
    marginTop: 20, 
  },
  iconWrapper: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  iconLabel: {
    fontSize: 14,
    color: '#fff',
    marginTop: 5,
  },
});

export default Home;
