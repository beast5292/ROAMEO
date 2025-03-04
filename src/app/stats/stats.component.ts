import { Component, AfterViewInit, ViewChildren, QueryList, ElementRef } from '@angular/core';
import { gsap } from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

@Component({
  selector: 'app-stats',
  templateUrl: './stats.component.html',
  styleUrls: ['./stats.component.css']
})
export class StatsComponent implements AfterViewInit {
  @ViewChildren('statBox') statBoxes!: QueryList<ElementRef>;

  constructor() {}

  ngAfterViewInit() {
    // Register the ScrollTrigger plugin
    gsap.registerPlugin(ScrollTrigger);

    // Convert QueryList to an array
    const columns = this.statBoxes.toArray().map(ref => ref.nativeElement);

    // We'll create a timeline that controls all columns
    // Each column will animate in from left to right as you scroll down,
    // and reverse that animation as scroll up.
    columns.forEach((col, index) => {
      gsap.fromTo(
        col,
        {
          x: -400,       // Start a bit left
          opacity: -1
        },
        {
          x: 0,
          opacity: 1,
          duration: 0.6,
          scrollTrigger: {
            trigger: col,
            start: 'top 100%',   // Start anim when top of col hits 80% of viewport
            end: 'top 10%',     // End anim when top of col hits 30% of viewport
            scrub: true,        // Smoothly animate with scroll
            // markers: true,   // Uncomment for debugging
            onEnter: () => console.log(`Entering column ${index + 1}`),
            onLeaveBack: () => console.log(`Leaving column ${index + 1}`)
          }
        }
      );
    });
  }
}
