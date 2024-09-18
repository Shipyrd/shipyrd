// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@fortawesome/fontawesome-free"
import "timeago";
import ClipboardJS from 'clipboard'

document.addEventListener('turbo:load', (event) => {
  const timeago_nodes = document.querySelectorAll('.timeago');
  if (timeago_nodes.length > 0) {
    timeago.render(timeago_nodes);
  }

  // Copy to clipboard for key installation on servers
  const clipboard = new ClipboardJS('.clipboard');
  clipboard.on('success', function (e) {
    e.trigger.textContent = "Copied!";
    e.clearSelection();
  });
})