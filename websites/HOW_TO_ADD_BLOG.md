# How to Add a New Blog Post

This guide explains how to add new blog posts to your website using the static JSON blog system.

## Quick Overview

To add a new blog post, you need to:
1. Write your blog content in an HTML file
2. Add an entry to `blogs.json`
3. Upload files to your server/S3

That's it! No coding required.

---

## Important: Testing Locally

Because the blog system fetches data from `blogs.json`, modern browsers will block this if you open the file directly (due to CORS policy).

**To test locally, you MUST run a local server:**

### Option 1: Using Python (Recommended)
1. Open terminal in the `websites` directory
2. Run: `python -m http.server 8000`
3. Open browser: `http://localhost:8000/blog.html`

### Option 2: Using VS Code Live Server
1. Install "Live Server" extension
2. Right-click on `blog.html`
3. Select "Open with Live Server"

---

## Step-by-Step Guide

### Step 1: Create Blog Content File

1. Navigate to the `blog-posts/` directory
2. Create a new HTML file with a descriptive name (use lowercase and hyphens)
   - Example: `kubernetes-deployment-guide.html`

3. Use this template for your blog content:

```html
<div class="blog-content">
    <h1>Your Blog Title Here</h1>
    
    <div class="meta-info">
        <span class="date">10 Februari 2026</span>
        <span class="read-time">5 min read</span>
    </div>
    
    <img src="../assets/your-image.jpg" alt="Description" />

    <h2>Introduction</h2>
    <p>
        Your introduction paragraph here...
    </p>

    <h2>Main Content Section</h2>
    <p>Your content here...</p>

    <ul>
        <li>Bullet point 1</li>
        <li>Bullet point 2</li>
    </ul>

    <h2>Code Examples (Optional)</h2>
    <pre><code>// Your code here
const example = "Hello World";
</code></pre>
</div>

<style>
/* Use standard styles, no need to add custom styles unless necessary */
</style>
```

### Step 2: Update blogs.json

1. Open `blogs.json` file
2. Add a new entry to the `posts` array
3. Make sure to:
   - Use a unique `id` (increment from the last post)
   - Set the correct `date` (format: YYYY-MM-DD)
   - Add relevant `tags`
   - Point `contentPath` to your new HTML file
   - Set `status` to `"published"` when ready

**Example:**

```json
{
  "posts": [
    {
      "id": 7,
      "title": "Kubernetes Deployment Best Practices",
      "date": "2026-03-15",
      "description": "Learn how to deploy applications to Kubernetes",
      "tags": ["Kubernetes", "DevOps"],
      "contentPath": "blog-posts/kubernetes-deployment-guide.html",
      "readTime": "10 min read",
      "status": "published"
    },
    ... (existing posts)
  ]
}
```

### Step 3: Upload to Server

If you're using AWS S3 (like in Cloud Resume Challenge):

```bash
# Upload new content
aws s3 cp blog-posts/your-new-post.html s3://your-bucket/blog-posts/

# Upload updated blogs.json
aws s3 cp blogs.json s3://your-bucket/

# Invalidate CloudFront cache (if using CloudFront)
aws cloudfront create-invalidation --distribution-id YOUR_DIST_ID --paths "/blogs.json" "/blog-posts/*"
```

---

## Architecture Note

The system now uses **separate details pages** (`blog-details.html`) instead of a modal.
- Listing page: `blog.html`
- Detail page: `blog-details.html?id=XXX`

When you click a blog post, it navigates to the detail page which fetches the content dynamically.

---

## Example Workflow

Here's a typical workflow for adding a new blog post:

```bash
# 1. Create new blog content file
cd websites/blog-posts
touch my-new-post.html
# (Edit the file with your content)

# 2. Update blogs.json
cd ..
# (Edit blogs.json to add new entry)

# 3. Test locally
# Open blog.html in browser to verify

# 4. Commit and push (if using Git)
git add .
git commit -m "Add blog post: My New Post"
git push origin main

# 5. Deploy (automatic via CI/CD or manual upload to S3)
```

---

## Need Help?

If you encounter any issues or have questions:
- Check the browser console for error messages
- Validate your JSON at [jsonlint.com](https://jsonlint.com)
- Review the existing blog posts as examples
- Contact: andiyusdaralimran@gmail.com

Happy blogging! 🚀
