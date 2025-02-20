import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-product',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './product.component.html',
  styleUrls: ['./product.component.css']
})
export class ProductComponent {
  // Features Section
  features = [
    {
      name: 'Personalized Itinerary Creation',
      briefDescription: '{brief description here}',
      detailedDescription: '{detailed description here}',
      expanded: false
    },
    {
      name: 'Sightseeing Mode',
      briefDescription: '{brief description here}',
      detailedDescription: '{detailed description here}',
      expanded: false
    },
    {
      name: 'Juliet Your AI Companion',
      briefDescription: '{brief description here}',
      detailedDescription: '{detailed description here}',
      expanded: false
    },
    {
      name: 'Make a Booking',
      briefDescription: '{brief description here}',
      detailedDescription: '{detailed description here}',
      expanded: false
    }
  ];

  toggleFeature(feature: any) {
    feature.expanded = !feature.expanded;
  }

  // Reviews Section
  currentIndex: number = 0;

  reviews = [
    { text: 'Review 1', person: 'Person 1' },
    { text: 'Review 2', person: 'Person 2' },
    { text: 'Review 3', person: 'Person 3' },
    { text: 'Review 4', person: 'Person 4' },
    { text: 'Review 5', person: 'Person 5' },
    { text: 'Review 6', person: 'Person 6' },
    { text: 'Review 7', person: 'Person 7' },
    { text: 'Review 8', person: 'Person 8' }
  ];

  scrollReviews(direction: string) {
    if (direction === 'forward' && this.currentIndex < this.reviews.length - 1) {
      this.currentIndex++;
    } else if (direction === 'back' && this.currentIndex > 0) {
      this.currentIndex--;
    }
  }

  // FAQ Section
  faqs = [
    { question: 'Question 1', answer: 'Answer 1', expanded: false },
    { question: 'Question 2', answer: 'Answer 2', expanded: false },
    { question: 'Question 3', answer: 'Answer 3', expanded: false },
    { question: 'Question 4', answer: 'Answer 4', expanded: false },
    { question: 'Question 5', answer: 'Answer 5', expanded: false }
  ];

  toggleFAQ(faq: any) {
    faq.expanded = !faq.expanded;
  }
}
