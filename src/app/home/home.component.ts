// home.component.ts
import { Component, ViewChild, ElementRef, AfterViewInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { StatsComponent } from "../stats/stats.component";

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule, StatsComponent],
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css']
})
export class HomeComponent implements AfterViewInit {
  @ViewChild('backgroundVideo') videoRef!: ElementRef<HTMLVideoElement>;

  ngAfterViewInit() {
    const video = this.videoRef.nativeElement;
    
    // Set video properties programmatically
    video.muted = true; // Ensure muted state
    video.playsInline = true; // For iOS compatibility
    
    // Auto-play with fallback
    const playAttempt = () => {
      video.play()
        .catch(error => {
          // Add slight delay for mobile devices
          setTimeout(() => video.play(), 300);
        });
    };

    // First attempt
    playAttempt();
    
    // Retry when video becomes visible
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          playAttempt();
        }
      });
    }, { threshold: 0.5 });

    observer.observe(video);
  }
}