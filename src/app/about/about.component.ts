import { Component, AfterViewInit, HostListener } from '@angular/core';

@Component({
  selector: 'app-about',
  templateUrl: './about.component.html',
  styleUrls: ['./about.component.css']
})
export class AboutComponent implements AfterViewInit {

  @HostListener('window:scroll', [])
  onScroll(): void {
    this.revealSections();
  }

  ngAfterViewInit(): void {
    // Delay execution slightly to allow DOM elements to load
    setTimeout(() => {
      this.revealSections();
    }, 300);
  }

  revealSections() {
    const sections = document.querySelectorAll('.about-right section');
    if (!sections.length) return; // Ensure sections exist

    const triggerHeight = window.innerHeight * 0.8;

    sections.forEach((section) => {
      const sectionTop = section.getBoundingClientRect().top;
      if (sectionTop < triggerHeight) {
        section.classList.add('reveal');
      }
    });
  }
}
