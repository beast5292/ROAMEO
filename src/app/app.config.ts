import { HomeComponent } from './home/home.component';
import { AboutComponent } from './about/about.component';
import { ProductComponent } from './product/product.component';
import { provideRouter } from '@angular/router';
import { ApplicationConfig } from '@angular/core';

const routes = [
  { path: '', component: HomeComponent },   // Default route. This will load the home page as default
  { path: 'about', component: AboutComponent },   // Path for about
  { path: 'product', component: ProductComponent},    // Path for products
  { path: '**', redirectTo: ''}   // Redirect to home for unknown routes
];

export const appConfig: ApplicationConfig = {
  providers: [provideRouter(routes)]
};