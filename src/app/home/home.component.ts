import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { StatsComponent } from "../stats/stats.component";

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule, StatsComponent],
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css']
})
export class HomeComponent {}