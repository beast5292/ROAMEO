import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';

interface FAQ {
  question: string;
  answer: string;
  expanded: boolean;
}

@Component({
  selector: 'app-product',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './product.component.html',
  styleUrls: ['./product.component.css']
})
export class ProductComponent implements OnInit, OnDestroy {
  // Features Section
  features = [
    {
      name: 'Personalized Itinerary Creation',
      briefDescription: 'Design Your Dream Journey – Your Way!',
      detailedDescription: 'Why follow a set itinerary when you can craft your own adventure? With Roameo, you’re both the guide and the traveler. Simply enter your preferred destinations, travel style, and budget, and let our AI create the perfect journey tailored just for you. Whether you seek relaxation, adventure, or hidden gems, we make sure your trip is uniquely yours.',
      expanded: false
    },
    {
      name: 'Sightseeing Mode',
      briefDescription: 'See More, Miss Less!',
      detailedDescription: 'Never overlook a breathtaking view again! Our Sightseeing Mode keeps you informed about must-see attractions, hidden landmarks, and stunning sceneries along your journey. Whether you\'re strolling through historic streets or cruising along scenic highways, we ensure you capture every unforgettable moment.',
      expanded: false
    },
    {
      name: 'Juliet Your AI Companion',
      briefDescription: 'Roam with Juliet, No Heartbreaks – Just Perfect Trips!',
      detailedDescription: 'Say hello to Juliet, your witty and ever-reliable AI travel assistant! She’s here to ensure your love story with travel is nothing but smooth sailing. Whether you need itinerary suggestions, real-time tips, or local insights, Juliet is always ready to guide you—no tragic endings, just perfect adventures!',
      expanded: false
    },
    {
      name: 'Make a Booking',
      briefDescription: 'Your Next Stop, Just a Tap Away!',
      detailedDescription: 'Need a cozy place to stay or a ride to your next destination? With Roameo’s seamless booking system, securing accommodations and transport has never been easier. Whether it’s hailing a taxi, booking a boutique hotel, or finding the perfect staycation spot, we make your travel effortless—so you can focus on making memories.',
      expanded: false
    }
  ];

  toggleFeature(feature: any) {
    // Close the currently expanded feature (if any)
    this.features.forEach(f => {
      if (f !== feature) {
        f.expanded = false;
      }
    });

    // Toggle the current feature
    feature.expanded = !feature.expanded;
  }

  // Reviews Section
  currentIndex: number = 0;

  reviews = [
    { text: '"Roameo completely transformed the way I travel! As a solo traveler, I love the Personalized Itinerary Creation feature—it felt like the app truly understood my travel style. I discovered hidden gems I would’ve never found on my own. 10/10 would recommend!"', person: 'Person 1' },
    { text: '"I was skeptical at first, but wow—Roameo\'s AI-planned trips fit my budget perfectly! I wanted an affordable, adventure-packed journey, and Juliet (the AI assistant) nailed it. I saved money while still having the time of my life!"', person: 'Person 2' },
    { text: '"The Sightseeing Mode is a game-changer! I used to miss cool landmarks just because they weren’t on my map. With Roameo, I got real-time notifications about stunning spots nearby, making my trip so much more memorable."', person: 'Person 3' },
    { text: '"I travel for comfort and experiences, and Roameo’s seamless booking system was a lifesaver. Finding 5-star hotels, booking airport transfers, and even last-minute restaurant reservations was effortless. It felt like having a personal travel concierge!"', person: 'Person 4' },
    { text: '"Planning a trip always felt overwhelming until I found Roameo. It made everything so simple! Juliet (the AI assistant) was like a friendly guide, answering all my questions and suggesting the best places to visit. I felt so confident on my first solo trip!"', person: 'Person 5' },
    { text: '"Organizing a group trip used to be a nightmare—until Roameo! The AI created an itinerary that suited everyone’s interests, from foodies to thrill-seekers. Plus, booking accommodations for a group was super easy. Our trip was stress-free and absolutely unforgettable!"', person: 'Person 6' },
    { text: '"I love spontaneous trips, and Roameo helped me make the most of every moment. The AI itinerary feature adapted to my last-minute changes, and the app recommended adrenaline-packed activities that I didn’t even know existed!"', person: 'Person 7' },
    { text: '"As someone who works remotely, finding the right work-friendly spots while traveling is crucial. Roameo suggested coworking cafés, peaceful accommodations, and even great networking events. It’s like the app knew exactly what I needed!"', person: 'Person 8' }
  ];

  ngOnInit(): void {
    this.startReviewCarousel();
  }

  ngOnDestroy(): void {
    if (this.carouselInterval) {
      clearInterval(this.carouselInterval); // Clear the interval when the component is destroyed
    }
  }

  // Start the automatic review carousel (every 4 seconds)
  carouselInterval: any;
  startReviewCarousel() {
    this.carouselInterval = setInterval(() => {
      this.currentIndex = (this.currentIndex + 1) % this.reviews.length; // Reset to the first review after the last
    }, 4000); // Change every 4 seconds
  }

  // FAQ Section
  faqs: FAQ[] = [
    { question: 'What is Roameo?', answer: 'Roameo is a travel app that helps you plan personalized journeys, offering features like AI-generated itineraries, sightseeing suggestions, and easy bookings.', expanded: false },
    { question: 'How does the AI itinerary work?', answer: 'Simply input your travel preferences, including destinations, travel style, and budget, and Roameo’s AI will create a customized itinerary just for you.', expanded: false },
    { question: 'Can I book accommodations through Roameo?', answer: 'Yes, Roameo has an integrated booking system for finding and reserving accommodations, taxis, and other services for your trip.', expanded: false },
    { question: 'Does Roameo suggest activities?', answer: 'Yes, Roameo will recommend must-see attractions, hidden landmarks, and exciting activities based on your interests.', expanded: false },
    { question: 'Is there a fee for using Roameo?', answer: 'Roameo is free to use for basic features. Some premium services and bookings may require a fee.', expanded: false }
  ];

  toggleFAQ(faq: FAQ) {
    faq.expanded = !faq.expanded;
  }
}
