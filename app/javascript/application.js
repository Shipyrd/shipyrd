// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import 'timeago';

const timeago_nodes = document.querySelectorAll('.timeago');
timeago.render(timeago_nodes);